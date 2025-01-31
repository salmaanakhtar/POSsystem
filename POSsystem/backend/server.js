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
  price1: String,
  price2: String,
  price3: String,
  description: String,
  imageId: String,
});

const Product = mongoose.model('Product', productSchema);

const imageSchema = new mongoose.Schema({
  data: Buffer,
  contentType: String,
});

const Image = mongoose.model('Image', imageSchema);

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
  await Product.findByIdAndDelete(req.params.id);
  res.send({ message: 'Product deleted' });
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});