// ESLint flat config (ESLint 9+ no longer reads .eslintrc).
import tseslint from 'typescript-eslint';

export default tseslint.config(
    { ignores: ['out/**', 'node_modules/**'] },
    ...tseslint.configs.recommended,
);
