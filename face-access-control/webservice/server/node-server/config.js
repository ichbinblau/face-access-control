module.exports = {
    database: {
        file: "./db/data.db"
    },

    restify: {
        port: 8000,
        host: "10.239.76.41",
        options: {
            name: "Intel Facial Recognition Server"
        }
    },
    api: './api/swagger.json',

    mqtt: {
        backingStore: {

        },
        port: 1883,
        host: '10.239.76.41',
        http: {port: 3000, bundle: true, static: './'}  
    }
}
