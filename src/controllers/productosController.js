const axios = require('axios');

const getProductos = (req, res) => {
  axios.get('http://localhost:3000/api/productos')
    .then(response => {
      const productos = response.data;
      res.render('productos', { productos }); 
    })
    .catch(err => console.error('Error al obtener productos:', err));
};

const getProductoById = (req, res) => {
  axios.get(`http://localhost:3000/api/productos/${req.params.id}`)
    .then(response => {
      const producto = response.data;
      res.render('producto', { producto }); 
    })
    .catch(err => console.error('Error al obtener el producto:', err));
};

const insertarProducto = (req, res) => {
  axios.post('http://localhost:3000/api/productos', req.body)
    .then(() => {
      res.redirect('/productos'); 
    })
    .catch(err => console.error('Error al crear el producto:', err));
};

const actualizarProducto = (req, res) => {
  axios.put(`http://localhost:3000/api/productos/${req.params.id}`, req.body)
    .then(() => {
      res.redirect('/productos'); 
    })
    .catch(err => console.error('Error al actualizar el producto:', err));
};

const borrarProducto = (req, res) => {
  axios.delete(`http://localhost:3000/api/productos/${req.params.id}`)
    .then(() => {
      res.redirect('/productos'); 
    })
    .catch(err => console.error('Error al eliminar el producto:', err));
};

module.exports = {
  getProductos,
  getProductoById,
  insertarProducto,
  actualizarProducto,
  borrarProducto,
};
