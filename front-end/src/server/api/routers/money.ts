import { z } from "zod";

import { createTRPCRouter, protectedProcedure } from "~/server/api/trpc";

export const moneyRouter = createTRPCRouter({
  get: protectedProcedure
    .input(
      z.object({
        address: z.string(),
      }),
    )
    .query(async ({ input, ctx }) => {
      if (input.address === "null") return "null";
      const user = await ctx.db.user.findUnique({
        where: {
          address: input.address,
        },
      });
      return user?.money;
    }),
});
