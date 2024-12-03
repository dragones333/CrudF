const express = require('express');
const router = express.Router();
const Producto = require('../models/productos');

router.get('/products', async (req, res) => {
  try {
    const products = await Producto.find();
    res.json(products);
  } catch (err) {
    res.status(500).send(err);
  }
});

router.post('/products', async (req, res) => {
  try {
    const product = new Producto(req.body);
    await product.save();
    res.status(201).json(product);
  } catch (err) {
    res.status(400).send(err);
  }
});

router.put('/products/:id', async (req, res) => {
  try {
    const product = await Producto.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(product);
  } catch (err) {
    res.status(400).send(err);
  }
});

router.delete('/products/:id', async (req, res) => {
  try {
    await Producto.findByIdAndDelete(req.params.id);
    res.status(204).send();
  } catch (err) {
    res.status(500).send(err);
  }
});

module.exports = router;
