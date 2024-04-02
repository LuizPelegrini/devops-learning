dev:
preparacao: - pnpm install - pnpm prisma generate

execucao: - pnpm dev

prod:
preparacao: - pnpm install - pnpm prisma generate - pnpm build - pnpm prune --prod

execucao - pnpm start
