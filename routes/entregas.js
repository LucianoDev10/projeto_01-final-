const express = require('express');
const req = require('express/lib/request');
const { poolPromise } = require('../mysql');
const router = express.Router();
const mysql = require('../mysql').pool;
const mysqlPromise = require('../mysql').poolPromise;


///------------------ ADMIN

/// get all
// Função para obter todas as entregas
router.get('/', async (req, res, next) => {
    try {
        const connection = await poolPromise.getConnection();
        const [deliveries] = await connection.query('SELECT * FROM entrega;');
        connection.release(); // Liberar a conexão após a consulta
        res.status(200).json({ response: deliveries });
    } catch (error) {
        console.error('Erro ao buscar entregas:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// Rota para visualizar os dados detalhados de um pedido
router.post('/pedidosInd/:ped_id', async (req, res) => {
    try {
        const pedidoProdutoId = req.params.ped_id;
        const connection = await poolPromise.getConnection();

        const queryConsultarPedido = `
            SELECT p.pro_id, pp.pep_id, p.pro_descricao, p.pro_preco, pp.pep_frete, p.pro_foto FROM pedido_produto pp
            INNER JOIN pedidos pd ON pp.ped_id = pd.ped_id
            INNER JOIN produto p ON pp.pro_id = p.pro_id
            WHERE pd.ped_id = ?`;

        const [resultadoConsulta] = await connection.execute(queryConsultarPedido, [pedidoProdutoId]);

        if (resultadoConsulta.length === 0) {
            res.status(404).json({ mensagem: "Pedido individual não encontrado" });
        } else {
            const pedido = resultadoConsulta;
            res.status(200).json({ pedido });
        }

        connection.release(); // Liberar a conexão após a consulta
    } catch (error) {
        console.error('Erro ao buscar detalhes do pedido:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});



// Rota para encerrar um pedido
router.post('/Encerrado/:ped_id', async (req, res) => {
    const pedidoId = req.params.ped_id;
    const connection = await poolPromise.getConnection();

    try {
        // Verificar se o pedido com o ID fornecido está em andamento
        const [resultados] = await connection.execute('SELECT * FROM entrega WHERE ped_id = ?', [pedidoId]);

        if (resultados.length === 0) {
            res.status(400).json({ mensagem: 'Não foi encontrado nenhum entrega com o ID fornecido ou o entrega já está encerrado' });
            return;
        }

        const pedidoAtual = resultados[0];
        let mensagem;
        let status;
        let pedido;

        if (pedidoAtual.ent_status_admin === 'Pendente') {
            const queryAtualizarPedido = 'UPDATE entrega SET ent_status_admin = ? WHERE ped_id = ?';
            await connection.execute(queryAtualizarPedido, ['Aceito', pedidoId]);

            status = 200;
            pedido = { ped_id: pedidoId, ent_status_admin: 'Aceito' };
            mensagem = 'Entrega feita com sucesso';
        } else if (pedidoAtual.ent_status_admin === 'Aceito') {
            mensagem = 'A entrega já foi aceita';
            status = 400;
        }

        connection.release(); // Liberar a conexão após a consulta

        res.status(status).json({ mensagem, pedido });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        res.status(500).json({ mensagem: 'Erro interno do servidor', pedido: null });
    }
});



///------------------ ENTREGADOR

// ENTREGAS ABERTAS (get all - Entrega )
router.get('/entregador', async (req, res, next) => {
    try {
        const connection = await poolPromise.getConnection();
        const [resultados] = await connection.query('SELECT * FROM entrega WHERE ent_status_admin = "Aceito" AND ent_status_entregador = "Pendente";');
        connection.release();
        res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro ao buscar entregas para entregador:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});


//ROTA PARA MOSTRAR DADOS DO PEDIDO DO CLIENTE (get ind - Entrega )
router.get('/entregador/entregaInd/:ent_id', async (req, res, next) => {
    const ent_id = req.params.ent_id;
    try {
        const connection = await poolPromise.getConnection();
        const query = `
        SELECT
        e.*,
        j.usu_cep AS usu_cep,
        j.usu_telefone AS usu_telefone,
        j.usu_endereco AS usu_endereco,
        j.usu_numero AS usu_numero,
        j.usu_nome AS usu_nome
        FROM entrega AS e
        INNER JOIN pedidos AS p ON e.ped_id = p.ped_id
        INNER JOIN usuario AS j ON p.usu_id = j.usu_id
        WHERE e.ent_status_admin = 'Aceito' AND ent_status_entregador = 'Pendente' AND ent_id = ?;`;

        const [resultados] = await connection.execute(query, [ent_id]);

        connection.release();
        res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro ao buscar detalhes da entrega para entregador:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

//INSERIR DADOS DE ACEITAR O PEDIDO E QUANTO TEMPO VAI LEVAR
router.post('/dados/:ent_id/:usu_id/:ent_minutos/:ent_valorFrete', async (req, res) => {
    const entId = req.params.ent_id;
    const usuarioId = req.params.usu_id;
    const minutos = req.params.ent_minutos;
    const valorFrete = req.params.ent_valorFrete;

    try {
        const connection = await poolPromise.getConnection();

        // Verificar se a entrega com o ID fornecido está em andamento
        const [resultados] = await connection.execute('SELECT * FROM entrega WHERE ent_id = ?', [entId]);

        if (resultados.length === 0) {
            res.status(400).json({ mensagem: 'Não foi encontrado nenhuma entrega com o ID fornecido ou a entrega já está encerrada' });
            connection.release();
            return;
        }

        const pedidoAtual = resultados[0];
        let mensagem;
        let status;
        let pedido;

        if (pedidoAtual.ent_status_entregador === 'Pendente') {
            const queryAtualizarPedido = 'UPDATE entrega SET ent_status_entregador = ?, usu_id = ?, ent_minutos = ?, ent_valorFrete = ? WHERE ent_id = ?';
            await connection.execute(queryAtualizarPedido, ['Aceito', usuarioId, minutos, valorFrete, entId]);

            status = 200;
            pedido = { ent_id: entId, ent_status_entregador: 'Aceito' };
            mensagem = 'Entrega aceita com sucesso';
        } else if (pedidoAtual.ent_status_entregador === 'Aceito') {
            mensagem = 'A entrega já foi aceita';
            status = 400;
        }

        connection.release(); // Liberar a conexão após a consulta

        res.status(status).json({ mensagem, pedido });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        res.status(500).json({ mensagem: 'Erro interno do servidor', pedido: null });
    }
});



// ENTREGAS ACEITAS PELO MOTORISTA MAIS AINDA NÃO REALIZADAS (get all - Entrega aceita)
router.get('/entregador/entregasAceitas/:id', async (req, res) => {
    try {
        const usuId = req.params.id;

        const query = 'SELECT * FROM entrega WHERE usu_id = ? AND ent_status_entregador = ?';
        const [resultados] = await poolPromise.execute(query, [usuId, 'Aceito']);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhuma entrega aceita encontrada para esse entregador' });
        }

        return res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

// ENTREGAS ACEITAS INDIVIDUAL, TANTO ACEITAS QUANTOS REALIZADAS (get ind - Entrega aceita)

router.get('/entregador/entregasInd/:id', async (req, res) => {
    try {
        const entregaId = req.params.id;

        const query = `
            SELECT
                e.*,
                j.usu_cep AS usu_cep,
                j.usu_telefone AS usu_telefone,
                j.usu_endereco AS usu_endereco,
                j.usu_numero AS usu_numero,
                j.usu_nome AS usu_nome
            FROM entrega AS e
            INNER JOIN pedidos AS p ON e.ped_id = p.ped_id
            INNER JOIN usuario AS j ON p.usu_id = j.usu_id
            WHERE ent_id = ?;
        `;

        const [resultados] = await poolPromise.execute(query, [entregaId]);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhuma entrega encontrada para esse ID' });
        }

        return res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});


// ENTREGAS ACEITAS E VIRAM REALIZADAS
router.post('/entregador/realizada/:ent_id', async (req, res) => {
    try {
        const entregaId = req.params.ent_id;

        const queryVerificarPedido = 'SELECT * FROM entrega WHERE ent_id = ?';
        const [resultados] = await poolPromise.execute(queryVerificarPedido, [entregaId]);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhuma entrega encontrada para esse ID' });
        }

        const pedidoAtual = resultados[0];

        if (pedidoAtual.ent_status_admin === 'Aceito') {
            const queryAtualizarPedido = 'UPDATE entrega SET ent_status_entregador = ? WHERE ent_id = ?';
            await poolPromise.execute(queryAtualizarPedido, ['Entregue', entregaId]);

            return res.status(200).json({ mensagem: 'Entrega realizada com sucesso', pedido: { ent_id: entregaId, ent_status_admin: 'Entregue' } });
        } else if (pedidoAtual.ent_status_admin === 'Entregue') {
            return res.status(400).json({ mensagem: 'A entrega já foi realizada' });
        } else {
            return res.status(400).json({ mensagem: 'A entrega não pode ser realizada. Verifique o status da entrega.' });
        }
    } catch (error) {
        console.error('Erro na requisição: ', error);
        res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});



// VALOR TOTAL DE ENTREGAS
router.get('/entregador/ValorTotal/:usu_id', async (req, res) => {
    try {
        const usu_id = req.params.usu_id;

        const query = `
            SELECT
                SUM(e.ent_valorFrete) AS valor_total,
                SUM(CASE WHEN MONTH(p.ped_data) = MONTH(NOW()) THEN e.ent_valorFrete ELSE 0 END) AS valor_total_mes
            FROM entrega AS e
            INNER JOIN pedidos AS p ON e.ped_id = p.ped_id
            WHERE e.ent_status_entregador = 'Entregue' 
                AND e.usu_id = ?;
        `;

        const [resultados] = await poolPromise.execute(query, [usu_id]);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum valor encontrado para este entregador' });
        }

        return res.status(200).json({ response: resultados[0] });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});



//PEDIDOS REALIZADOS PELO ENTREGADOR (get all - Entrega realizada)

router.get('/entregador/entregasRealizadas/:id', async (req, res) => {
    try {
        const usuId = req.params.id;

        const query = `SELECT * FROM entrega WHERE usu_id = ? AND ent_status_entregador = 'Entregue';`;

        const [resultados] = await poolPromise.execute(query, [usuId]);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum entrega realizada encontrada para este entregador' });
        }

        return res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

module.exports = router;