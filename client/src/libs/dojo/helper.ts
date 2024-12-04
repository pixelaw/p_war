import { Pixel } from "@/types";
import { ProposalType } from "@/libs/dojo/typescript/models.gen";
import { uint32ToRgba } from "@/utils";

import { Entities, Entity, ToriiClient } from "@dojoengine/torii-client";

export const getProposalFromEntity = (entity: Entity) => {
  return {
    author: BigInt(entity["pixelaw-Proposal"].author.value as string),
    start: entity["pixelaw-Proposal"].start.value as number,
    proposal_type: entity["pixelaw-Proposal"].proposal_type.value as ProposalType,
    target_args_2: entity["pixelaw-Proposal"].target_args_2.value as number,
    end: entity["pixelaw-Proposal"].end.value as number,
    index: entity["pixelaw-Proposal"].index.value as number,
    yes_voting_power: entity["pixelaw-Proposal"].yes_voting_power.value as number,
    no_voting_power: entity["pixelaw-Proposal"].no_voting_power.value as number,
    target_args_1: entity["pixelaw-Proposal"].target_args_1.value as number,
    game_id: entity["pixelaw-Proposal"].game_id.value as number,
    is_activated: entity["pixelaw-Proposal"].is_activated.value as boolean,
  };
};

export const getPixelComponentValue = (entity: Entity): Pixel => {
  return {
    x: entity["pixelaw-Pixel"].x.value as number,
    y: entity["pixelaw-Pixel"].y.value as number,
    color: uint32ToRgba(entity["pixelaw-Pixel"].color.value as number),
  };
};

export const getPixelComponentFromEntities = (entities: Entities) => {
  return Object.values(entities).map(getPixelComponentValue);
};

export const getPixelEntities = async (
  client: ToriiClient,
  limit: number,
  {
    upperLeftX,
    upperLeftY,
    lowerRightX,
    lowerRightY,
  }: { upperLeftX: number; upperLeftY: number; lowerRightX: number; lowerRightY: number },
) => {
  const entities = await client.getEntities({
    limit,
    offset: 0,
    dont_include_hashed_keys: true,
    clause: {
      Composite: {
        operator: "And",
        clauses: [
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "x",
              operator: "Gte",
              value: { Primitive: { U32: upperLeftX } },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "y",
              operator: "Gte",
              value: { Primitive: { U32: upperLeftY } },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "x",
              operator: "Lte",
              value: { Primitive: { U32: lowerRightX } },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "y",
              operator: "Lte",
              value: { Primitive: { U32: lowerRightY } },
            },
          },
        ],
      },
    },
  });

  return entities;
};
