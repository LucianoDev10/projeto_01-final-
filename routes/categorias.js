const express = require('express');
const router = express.Router();
const mysql = require('../mysql').pool;
const { poolPromise } = require('../mysql');


// Rota para retornar todas as categorias
router.get('/', async (req, res) => {
    try {
        const query = 'SELECT * FROM categorias;';
        const [resultados] = await poolPromise.execute(query);

        return res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

// Rota para retornar produtos de uma categoria específica
router.get('/:id', async (req, res) => {
    try {
        const idCategoria = req.params.id;
        const query = 'SELECT * FROM produto WHERE cat_id = ?;';
        const [resultados] = await poolPromise.execute(query, [idCategoria]);

        if (resultados.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum produto encontrado para essa categoria' });
        }

        return res.status(200).json({ response: resultados });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});



// Rota para inserir uma nova categoria
router.post('/', async (req, res) => {
    try {
        const categoria = {
            cat_nome: req.body.cat_nome,
            cat_icons: req.body.cat_icons
        };

        const query = 'INSERT INTO categorias (cat_nome, cat_icons) VALUES (?, ?);';
        const [resultado] = await poolPromise.execute(query, [categoria.cat_nome, categoria.cat_icons]);

        categoria.cat_id = resultado.insertId;

        return res.status(201).json({ message: 'Categoria criada com sucesso', categoria: categoria });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

// Rota para atualizar uma categoria existente
router.put('/:catId', async (req, res) => {
    try {
        const catId = req.params.catId; // ID da categoria a ser atualizada
        const updatedCategoria = {
            cat_nome: req.body.cat_nome,
            cat_icons: req.body.cat_icons
        };

        const query = 'UPDATE categorias SET cat_nome = ?, cat_icons = ? WHERE cat_id = ?';
        const [resultado] = await poolPromise.execute(query, [updatedCategoria.cat_nome, updatedCategoria.cat_icons, catId]);

        if (resultado.affectedRows === 0) {
            return res.status(404).json({ message: 'Categoria não encontrada' });
        }

        return res.status(200).json({ message: 'Categoria atualizada com sucesso' });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});



// Rota para atualizar uma categoria
router.get('/atualizar/:id', async (req, res) => {
    try {
        const idCategoria = req.params.id;

        const query = 'SELECT * FROM categorias where cat_id = ?;';
        const [resultado] = await poolPromise.execute(query, [idCategoria]);

        if (resultado.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhuma categoria encontrada para atualização' });
        }

        const categoria = resultado[0];

        return res.status(200).json({ categoria });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

// Rota para excluir uma categoria
router.delete('/excluir/:id', async (req, res) => {
    try {
        const idCategoria = req.params.id;

        const deleteQuery = 'DELETE FROM categorias WHERE cat_id = ?';
        const [results] = await poolPromise.execute(deleteQuery, [idCategoria]);

        if (results.affectedRows === 0) {
            return res.status(404).json({ mensagem: 'Nenhuma categoria encontrada para exclusão' });
        }

        return res.status(200).json({ mensagem: 'Categoria excluída com sucesso' });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});



module.exports = router;