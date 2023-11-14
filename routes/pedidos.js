const express = require('express');
const req = require('express/lib/request');
const { poolPromise } = require('../mysql');
const router = express.Router();
const mysql = require('../mysql').pool;
const mysqlPromise = require('../mysql').poolPromise;



// CONSULTAR OS DADOS
router.get('/:id_usuario', async (req, res) => {
    try {
        const idUsuario = req.params.id_usuario;

        const query = 'SELECT * FROM pedidos WHERE usu_id = ?;';
        const [resultado] = await poolPromise.execute(query, [idUsuario]);

        if (resultado.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum pedido encontrado para este usuário' });
        }

        return res.status(200).json({ response: resultado });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});


/// SEMPRE CRIA UM NOVO PEDIDO EM ANDAMENTO
router.post('/pedidoAndamento/:id_usuario', async (req, res) => {
    const usuarioId = req.params.id_usuario;

    try {
        const connection = await poolPromise.getConnection();

        // Verificar se o usuário já possui um pedido em andamento ou encerrado
        const queryVerificarPedido = 'SELECT * FROM pedidos WHERE usu_id = ? ORDER BY ped_data DESC LIMIT 1';
        const [resultados] = await connection.execute(queryVerificarPedido, [usuarioId]);

        let mensagem;
        let status;
        let pedido;
        const dataHoraFormatada = new Date().toISOString().slice(0, 19).replace('T', ' ');

        if (resultados.length > 0) {
            const pedidoAtual = resultados[0];

            if (pedidoAtual.ped_status === 'Em andamento') {
                // O usuário já possui um pedido em andamento, retorná-lo
                status = 200;
                pedido = pedidoAtual;
            } else if (pedidoAtual.ped_status === 'Encerrado') {
                const novoPedido = {
                    usu_id: usuarioId,
                    ped_status: 'Em andamento',
                    ped_data: dataHoraFormatada,
                };

                const queryInserirPedido = 'INSERT INTO pedidos (usu_id, ped_status, ped_data) VALUES (?, ?, ?)';
                const [resultadoInserir] = await connection.execute(queryInserirPedido, [
                    novoPedido.usu_id,
                    novoPedido.ped_status,
                    novoPedido.ped_data,
                ]);

                const pedidoId = resultadoInserir.insertId; // ID do pedido recém-criado

                status = 200;
                pedido = { ped_id: pedidoId, ...novoPedido };
            }
        } else {
            const novoPedido = {
                usu_id: usuarioId,
                ped_status: 'Em andamento',
                ped_data: dataHoraFormatada,
            };

            const queryInserirPedido = 'INSERT INTO pedidos (usu_id, ped_status, ped_data) VALUES (?, ?, ?)';
            const [resultadoInserir] = await connection.execute(queryInserirPedido, [
                novoPedido.usu_id,
                novoPedido.ped_status,
                novoPedido.ped_data,
            ]);

            const pedidoId = resultadoInserir.insertId; // ID do pedido recém-criado

            status = 200;
            pedido = { ped_id: pedidoId, ...novoPedido };
        }

        connection.release(); // Liberar a conexão após a consulta

        return res.status(status).json({ mensagem, pedido });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor', pedido: null });
    }
});


// ROTA PARA ADICIONAR PRODUTOS A UM PRODUTO
router.post('/produtos/:ped_id/:pro_id', async (req, res) => {
    const pedidoId = req.params.ped_id;
    const produtoId = req.params.pro_id;
    const connection = await poolPromise.getConnection();

    try {
        const novoPedidoProduto = {
            ped_id: pedidoId,
            pro_id: produtoId,
        };

        const queryInserirPedidoProduto = 'INSERT INTO pedido_produto (ped_id, pro_id) VALUES (?, ?)';
        const [resultadoInserir] = await connection.execute(queryInserirPedidoProduto, [
            novoPedidoProduto.ped_id,
            novoPedidoProduto.pro_id,
        ]);

        const pedidoProdutoId = resultadoInserir.insertId;

        connection.release();

        return res.status(200).json({ pedidoProdutoId });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        connection.release();
        return res.status(500).json({ mensagem: 'Erro interno do servidor', pedidoProdutoId: null });
    }
});


// ROTA PARA VISUALIZAR OS DADOS DETALHADOS
router.get('/pedidosInd/:ped_id', async (req, res) => {
    const pedidoProdutoId = req.params.ped_id;
    const connection = await poolPromise.getConnection();

    try {
        const queryConsultarPedido = `
        SELECT p.pro_id, pp.pep_id, p.pro_descricao, p.pro_preco, pp.pep_frete, p.pro_foto FROM pedido_produto pp
        INNER JOIN pedidos pd ON pp.ped_id = pd.ped_id
        INNER JOIN produto p ON pp.pro_id = p.pro_id
        WHERE pd.ped_id = ?`;

        const [resultadoConsulta] = await connection.execute(queryConsultarPedido, [pedidoProdutoId]);

        if (resultadoConsulta.length === 0) {
            return res.status(404).json({ mensagem: "Pedido individual não encontrado" });
        }

        const pedido = resultadoConsulta;
        const status = 200;

        connection.release(); // Liberar a conexão após a consulta
        return res.status(status).json({ pedido });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        connection.release();
        return res.status(500).json({ mensagem: 'Erro interno do servidor', pedido: null });
    }
});


//ROTA PARA ENCERRAR UM PEDIDO E CRIAR UMA ENTREGA
router.post('/pedidoEncerrado/:ped_id', async (req, res) => {
    const pedidoId = req.params.ped_id;
    const connection = await poolPromise.getConnection();

    try {
        const dataHoraFormatada = new Date().toISOString().slice(0, 19).replace('T', ' ');

        const queryVerificarPedido = 'SELECT * FROM pedidos WHERE ped_id = ?';
        const [resultados] = await connection.execute(queryVerificarPedido, [pedidoId]);

        let mensagem;
        let status;
        let pedido;

        if (resultados.length > 0) {
            const pedidoAtual = resultados[0];

            if (pedidoAtual.ped_status === 'Em andamento') {
                const queryAtualizarPedido = 'UPDATE pedidos SET ped_status = ?, ped_data = ? WHERE ped_id = ?';
                await connection.execute(queryAtualizarPedido, ['Encerrado', dataHoraFormatada, pedidoId]);

                const queryInserirEntrega = 'INSERT INTO entrega (ent_status_admin, ent_status_entregador,  ent_valorFrete, usu_id, ped_id) VALUES (?, ?, ?, ?, ?)';
                await connection.execute(queryInserirEntrega, ['Pendente', 'Pendente', null, null, pedidoId]);

                status = 200;
                pedido = { ped_id: pedidoId, ped_status: 'Encerrado', ped_data: dataHoraFormatada };
                mensagem = 'Pedido encerrado com sucesso';

            } else if (pedidoAtual.ped_status === 'Encerrado') {
                mensagem = 'O pedido já está encerrado';
                status = 400;
            }
        } else {
            mensagem = 'Não foi encontrado nenhum pedido com o ID fornecido ou o pedido já está encerrado';
            status = 400;
        }

        connection.release(); // Liberar a conexão após a consulta

        res.status(status).json({ mensagem, pedido });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        connection.release();
        res.status(500).json({ mensagem: 'Erro interno do servidor', pedido: null });
    }
});



module.exports = router;