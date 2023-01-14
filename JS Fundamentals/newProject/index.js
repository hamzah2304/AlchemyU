const { faker } = require('@faker-js/faker');
const name = faker.name.fullName();
const message = `Hello, ${name}!`;
console.log(message);