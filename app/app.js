const express = require('express');

const app  = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.status(200).json({ message: 'Hello World of Gitlab' })
})

app.listen(port, () => {
    console.log(`App started on port ${port}.`)
});

module.exports = app;
