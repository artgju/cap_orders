/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testTimeout: 60000,
  verbose: true,
  collectCoverage: false,
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov"],
  testMatch: ["**/test/**/*.test.js"],
  modulePathIgnorePatterns: ["<rootDir>/node_modules/"],
};
