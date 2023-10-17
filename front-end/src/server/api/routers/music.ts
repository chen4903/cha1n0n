import { z } from "zod";

import {
  createTRPCRouter,
  protectedProcedure,
  publicProcedure,
} from "~/server/api/trpc";

import { Prisma } from "@prisma/client";

const defaultMusicSelect = Prisma.validator<Prisma.MusicSelect>()({
  title: true,
  description: true,
  image: true,
  path: true,
  author: true,
  createdAt: true,
  id: true,
});

export const musicRouter = createTRPCRouter({
  create: protectedProcedure
    .input(
      z.object({
        title: z.string().min(1),
        description: z.string(),
        image: z.boolean(),
        path: z.string(),
        author: z.string(),
      }),
    )
    .mutation(async ({ ctx, input }) => {
      // simulate a slow db call
      console.log("input.author", input.author);
      console.log("ctx.session.user.id", ctx.session.user.id);
      await new Promise((resolve) => setTimeout(resolve, 1000));

      return ctx.db.music.create({
        data: {
          title: input.title,
          description: input.description,
          image: input.image,
          path: input.path,
          author: input.author,
          createdBy: { connect: { address: ctx.session.user.id } },
        },
      });
    }),

  getLatest: protectedProcedure
    .input(
      z.object({
        author: z.string(),
      }),
    )
    .query(({ ctx, input }) => {
      if (input.author === "null") return undefined;
      return ctx.db.music.findMany({
        take: 2,
        orderBy: { createdAt: "desc" },
        where: { createdById: input.author },
      });
    }),

  list: protectedProcedure.query(({ ctx, input }) => {
    return ctx.db.music.findMany({
      select: defaultMusicSelect,
      orderBy: { createdAt: "desc" },
      where: {},
    });
  }),

  byAddress: protectedProcedure
    .input(
      z.object({
        author: z.string(),
      }),
    )
    .query(({ ctx, input }) => {
      if (input.author === "null") return undefined;
      return ctx.db.music.findMany({
        orderBy: { createdAt: "desc" },
        where: { createdById: input.author },
      });
    }),
});
