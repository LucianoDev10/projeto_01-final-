const express = require('express');
const req = require('express/lib/request');
const router = express.Router();
const { poolPromise } = require('../mysql');

const mysql = require('../mysql').pool;

//RETORNA TODOS OS PRODUTOS
router.get('/', async (req, res, next) => {
    const query = 'SELECT * FROM produto;';

    try {
        const conn = await poolPromise.getConnection();
        const [resultado] = await conn.query(query);
        conn.release(); // Liberar a conexão após a consulta
        return res.status(200).send({ response: resultado });
    } catch (error) {
        return res.status(500).send({ error: error });
    }
});


//RETORNA TODOS OS PRODUTOS
router.get('/melhoresPrecos', async (req, res, next) => {
    const query = `
        SELECT p.*
        FROM produto AS p
        INNER JOIN (
            SELECT cat_id, MIN(pro_preco) AS min_preco
            FROM produto
            GROUP BY cat_id
        ) AS sub
        ON p.cat_id = sub.cat_id AND p.pro_preco = sub.min_preco;
    `;

    try {
        const conn = await poolPromise.getConnection();
        const [resultado] = await conn.query(query);
        conn.release(); // Liberar a conexão após a consulta
        return res.status(200).send({ response: resultado });
    } catch (error) {
        return res.status(500).send({ error: error });
    }
});


//RETORNA OS DADOS DE UM PRODUTO APENAS
router.get('/:id_produto', async (req, res, next) => {
    try {
        const conn = await poolPromise.getConnection();
        const [resultado] = await conn.query('SELECT * FROM produto WHERE pro_id = ?;', [req.params.id_produto]);
        conn.release(); // Liberar a conexão após a consulta
        return res.status(200).send({ response: resultado });
    } catch (error) {
        return res.status(500).send({ error: error });
    }
});


router.patch('/', async (req, res, next) => {
    try {
        const conn = await poolPromise.getConnection();
        const query = `
            UPDATE produto
            SET pro_descricao = ?,
            pro_preco = ?,
            pro_qtd = ?
            WHERE pro_id = ?`;
        const values = [req.body.descricao, req.body.preco, req.body.qtd, req.body.id];
        const [resultado] = await conn.query(query, values);
        conn.release(); // Liberar a conexão
        if (resultado.affectedRows === 0) {
            return res.status(404).send({ mensagem: 'Produto não encontrado' });
        }
        return res.status(202).send({
            mensagem: 'Produto atualizado com sucesso',
            produtoAtualizado: {
                id: req.body.id,
                descricao: req.body.descricao,
                preco: req.body.preco,
                qtd: req.body.qtd,
            }
        });
    } catch (error) {
        return res.status(500).send({ error: error });
    }
});


router.post('/excluirProduto/:pep_id/:ped_id/:pro_id', async (req, res, next) => {
    try {
        const pedProdutoId = req.params.pep_id;
        const pedidoId = req.params.ped_id;
        const produtoId = req.params.pro_id;

        const conn = await poolPromise.getConnection();
        const query = `
            DELETE FROM pedido_produto
            WHERE pep_id = ? AND ped_id = ? AND pro_id = ?`;
        const values = [pedProdutoId, pedidoId, produtoId];
        const [resultado] = await conn.query(query, values);
        conn.release(); // Liberar a conexão

        if (resultado.affectedRows === 0) {
            return res.status(404).send({ mensagem: 'Produto não encontrado no pedido' });
        }

        return res.status(202).send({
            mensagem: 'Produto excluído com sucesso',
        });
    } catch (error) {
        return res.status(500).send({ error: error });
    }
});


//      ------> ADMIN <------

//mostrar os produtos das categorias

router.get('/categorias/:id', async (req, res, next) => {
    try {
        const idCategoria = req.params.id;

        const query = 'SELECT * FROM produto WHERE cat_id = ?';

        const conn = await poolPromise.getConnection();
        const [resultado] = await conn.query(query, [idCategoria]);
        conn.release(); // Libere a conexão após a consulta

        if (resultado.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum produto encontrado para essa categoria' });
        }

        return res.status(200).json({ produtos: resultado });
    } catch (error) {
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

//INSER UM PRODUTO
router.post('/categorias/:id', async (req, res, next) => {
    try {
        const idCategoria = req.params.id;

        const produto = {
            pro_descricao: req.body.pro_descricao,
            pro_preco: req.body.pro_preco,
            cat_id: idCategoria,
            pro_foto: req.body.pro_foto,
            pro_subDescricao: req.body.pro_subDescricao,
        };

        const conn = await poolPromise.getConnection();
        const query = 'INSERT INTO produto (pro_descricao, pro_preco, cat_id, pro_foto, pro_subDescricao) VALUES (?, ?, ?, ?, ?)';
        const [resultado] = await conn.query(query, [produto.pro_descricao, produto.pro_preco, produto.cat_id, produto.pro_foto, produto.pro_subDescricao]);
        conn.release();

        return res.status(201).json({ message: 'Produto criado com sucesso', produto });
    } catch (error) {
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});


//ATUALIZA UM PRODUTO
router.put('/:proId', async (req, res, next) => {
    try {
        const proId = req.params.proId;

        const updatedProduto = {
            pro_descricao: req.body.pro_descricao,
            pro_preco: req.body.pro_preco,
            pro_foto: req.body.pro_foto,
            pro_subDescricao: req.body.pro_subDescricao
        };

        const conn = await poolPromise.getConnection();
        const query = 'UPDATE produto SET pro_descricao = ?, pro_preco = ?, pro_foto = ?, pro_subDescricao = ? WHERE pro_id = ?';
        const [resultado] = await conn.query(query, [updatedProduto.pro_descricao, updatedProduto.pro_preco, updatedProduto.pro_foto, updatedProduto.pro_subDescricao, proId]);

        if (resultado.affectedRows === 0) {
            conn.release();
            return res.status(404).json({ message: 'Produto não encontrado' });
        }

        conn.release();
        return res.status(200).json({ message: 'Produto atualizado com sucesso' });
    } catch (error) {
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

//MOSTRA UM PRODUTO INDIVIDUAL
router.get('/atualizar/:id', async (req, res, next) => {
    const idProduto = req.params.id;

    // Verificar se idProduto é um número válido
    if (isNaN(idProduto)) {
        return res.status(400).json({ error: 'ID de produto inválido' });
    }

    try {
        const conn = await poolPromise.getConnection();
        const query = 'SELECT * FROM produto WHERE pro_id = ?;';
        const [resultado] = await conn.query(query, [idProduto]);

        if (resultado.length === 0) {
            conn.release(); // Liberar a conexão
            return res.status(404).json({ mensagem: 'Nenhum produto encontrado para esse ID' });
        }

        const produto = resultado[0]; // Obtenha o primeiro produto encontrado
        conn.release(); // Liberar a conexão

        return res.status(200).json({ produto });
    } catch (error) {
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});


//EXCLUI UM PRODUTO
router.delete('/excluir/:id', async (req, res, next) => {
    const idProduto = req.params.id;

    // Verificar se idProduto é um número válido
    if (isNaN(idProduto)) {
        return res.status(400).json({ error: 'ID de produto inválido' });
    }

    try {
        const conn = await poolPromise.getConnection();
        const deleteQuery = 'DELETE FROM produto WHERE pro_id = ?';
        const [results] = await conn.query(deleteQuery, [idProduto]);
        conn.release(); // Liberar a conexão

        if (results.affectedRows === 0) {
            return res.status(404).json({ mensagem: 'Nenhum produto encontrado para exclusão' });
        }

        return res.status(200).json({ mensagem: 'Produto excluído com sucesso' });
    } catch (error) {
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});


//ver dps
router.post('/', (req, res, next) => {

    //console.log(req.file);
    mysql.getConnection((error, conn) => {
        conn.query(
            'INSERT INTO produto (pro_descricao, pro_preco, pro_qtd, Supermercado_sup_id) VALUES (?, ?, ?, ?)',
            [req.body.descricao, req.body.preco, req.body.qtd, req.body.supermercado_id],
            (error, resultado, fields) => {
                conn.release(); // libera a conexão
                if (error) { // verifica se ocorreu algum erro na operação
                    return res.status(500).send({
                        error: error,
                        response: null
                    });
                }

                res.status(201).send({ // envia a resposta de sucesso com o produto criado
                    mensagem: 'Produto inserido com sucesso',
                    produtoCriado: {
                        pro_id: resultado.insertId,
                        descricao: req.body.descricao,
                        preco: req.body.preco,
                        qtd: req.body.qtd,
                        supermercado_id: req.body.supermercado_id
                    }
                });
            }
        );

    });

});

module.exports = router;