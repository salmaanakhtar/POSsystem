const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const uri = 'mongodb+srv://admin:admin@datastorage.xtyvnbn.mongodb.net/dataStorage?retryWrites=true&w=majority';
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });

const productSchema = new mongoose.Schema({
  name: String,
  price: String,
  description: String,
  imageId: String,
  active: { type: Boolean, default: true }, // <-- Add this line
});

const Product = mongoose.model('Product', productSchema);

const imageSchema = new mongoose.Schema({
  data: Buffer,
  contentType: String,
});

const Image = mongoose.model('Image', imageSchema);

const cartSchema = new mongoose.Schema({
  productId: String,
  quantity: Number,
  price: String,
});

const Cart = mongoose.model('Cart', cartSchema);

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.post('/upload', upload.single('image'), async (req, res) => {
  const newImage = new Image({
    data: req.file.buffer,
    contentType: req.file.mimetype,
  });
  await newImage.save();
  res.send({ id: newImage._id });
});

app.get('/image/:id', async (req, res) => {
  const image = await Image.findById(req.params.id);
  if (!image) {
    return res.status(404).send('Image not found');
  }
  res.set('Content-Type', image.contentType);
  res.send(image.data);
});

app.post('/products', async (req, res) => {
  const product = new Product(req.body);
  await product.save();
  res.send(product);
});

app.get('/products', async (req, res) => {
  const products = await Product.find();
  res.send(products);
});

app.put('/products/:id', async (req, res) => {
  const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.send(product);
});

app.delete('/products/:id', async (req, res) => {
  const product = await Product.findByIdAndDelete(req.params.id);
  if (product && product.imageId) {
    await Image.findByIdAndDelete(product.imageId);
  }
  res.send({ message: 'Product and associated image deleted' });
});

app.post('/cart', async (req, res) => {
  const cartItem = new Cart(req.body);
  await cartItem.save();
  res.send(cartItem);
});

app.get('/cart', async (req, res) => {
  const cartItems = await Cart.find();
  res.send(cartItems);
});

app.put('/cart/:id', async (req, res) => {
  const cartItem = await Cart.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.send(cartItem);
});

app.delete('/cart/:id', async (req, res) => {
  await Cart.findByIdAndDelete(req.params.id);
  res.send({ message: 'Cart item deleted' });
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});