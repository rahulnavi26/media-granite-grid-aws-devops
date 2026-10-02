const app = require('./app');
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`publishing-api listening on ${port}`));
