module.exports = [
  {
    files: ['**/*.js'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        require: 'readonly', module: 'writable', process: 'readonly',
        console: 'readonly', describe: 'readonly', test: 'readonly', expect: 'readonly',
      },
    },
    rules: { 'no-unused-vars': 'warn' },
  },
];
