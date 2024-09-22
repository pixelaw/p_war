import { useCallback, useEffect, useState } from "react";
import { Board } from "../types";
import { useDojo } from "./useDojo";
import { getBoardComponentFromEntities, getBoardComponentValue, getBoardEntities } from "@/libs/dojo/helper";
import { Entity } from "@dojoengine/torii-client";


const BOARD_LIMIT = 1;

export const useBoard = () => {
	const {
		setup: { toriiClient },
	} = useDojo();

	const [visibleBoards, setVisibleBoards] = useState<Board[]>([]);

	const fetchBoards = useCallback(async () => {
		try {
			const entities = await getBoardEntities(toriiClient, BOARD_LIMIT);
			const newBoards = getBoardComponentFromEntities(entities);
			
			if (newBoards.length === 0) {
				console.warn("No valid boards found");
			}
			
			setVisibleBoards(newBoards);
		} catch (error) {
			console.error("Error fetching boards:", error);
		} 
	}, [toriiClient]);

	// Effects
	useEffect(() => {
		const subscription = async () => {
			const sub = await toriiClient.onEntityUpdated([], (_entityId: any, entity: Entity) => {
				const board = getBoardComponentValue(entity);
				setVisibleBoards((prev) => [...prev, board].filter((b): b is Board => b !== undefined));
			});

			return sub;
		};

		const sub = subscription();
		return () => {
			sub.then((sub) => sub.cancel());
		};
	}, [toriiClient, setVisibleBoards]);

	// initial fetch
	useEffect(() => {
		fetchBoards();
	}, []);

	return { visibleBoards, fetchBoards };
};
