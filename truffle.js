module.exports = {
    migrations_directory: "./migrations",
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "3",
            gas: 3000000,
            gasPrice: 30000000000
        }
    }
};
