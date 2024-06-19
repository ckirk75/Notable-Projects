const express = require('express');
const app = express();
require('dotenv').config();

app.set('json spaces', 5); // to pretify json response

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`
    <h2>File Upload With <code>"Node.js"</code></h2>
    <form action="/api/upload" enctype="multipart/form-data" method="post">
      <div>Select a file: 
        <input type="file" name="file" multiple="multiple" />
      </div>
      <input type="submit" value="Upload" />
    </form>

  `);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}.`)
})