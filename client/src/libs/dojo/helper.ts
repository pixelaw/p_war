import { Pixel, Board, Position } from "@/types";
import { uint32ToRgba } from "@/utils";

import { Entities, Entity, ToriiClient } from "@dojoengine/torii-client";

// import { HasValue } from "@dojoengine/recs";

// import { getComponentValue } from "@dojoengine/recs";
// import { ClientComponents } from "./createClientComponents";

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
  }: { upperLeftX: number; upperLeftY: number; lowerRightX: number; lowerRightY: number }
) => {
  const entities = await client.getEntities({
    limit,
    offset: 0,
    clause: {
      Composite: {
        operator: "And",
        clauses: [
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "x",
              operator: "Gte",
              value: { U32: upperLeftX },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "y",
              operator: "Gte",
              value: { U32: upperLeftY },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "x",
              operator: "Lte",
              value: { U32: lowerRightX },
            },
          },
          {
            Member: {
              model: "pixelaw-Pixel",
              member: "y",
              operator: "Lte",
              value: { U32: lowerRightY },
            },
          },
        ],
      },
    },
  });

  return entities;
};


export const getBoardComponentValue = (entity: Entity): Board | undefined => {
  if (!entity["pixelaw-Board"]) {
    return undefined;
  }
  return {
    id: entity["pixelaw-Board"].id.value as number,
    origin: entity["pixelaw-Board"].origin.value as unknown as Position,
    width: entity["pixelaw-Board"].width.value as number,
    height: entity["pixelaw-Board"].height.value as number,
  };
};

export const getBoardComponentFromEntities = (entities: Entities): Board[] => {
  return Object.values(entities)
    .map(getBoardComponentValue)
    .filter((board): board is Board => board !== undefined);
};



export const getBoardEntities = async (
  client: ToriiClient,
  limit: number
) => {
  const entities = await client.getEntities({
    clause: undefined,
    limit,
    offset: 0,
  });
  return entities;
};
