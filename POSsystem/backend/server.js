const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const uri = 'mongodb+srv://admin:admin@datastorage.xtyvnbn.mongodb.net/dataStorage?retryWrites=true&w=majority';
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });

const productSchema = new mongoose.Schema({
  name: String,
  priceLocal: String,
  priceAway: String,
  description: String,
});

const Product = mongoose.model('Product', productSchema);

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