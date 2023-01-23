import express from "express";
const app = express();

(async () => {
    const port = process.env.PORT || 3000;
    const options = {
        host: "0.0.0.0",
        port,
    };
    app.get('/', (req, res) => {
        res.send('dog server')
    })
    app.listen(options, () => {
        console.log("server is on port " + 3000);
    });
})();