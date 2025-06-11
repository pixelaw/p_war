import { usePixelawProvider } from "@pixelaw/react";
import { useEffect, useRef, useState } from "react";
import { Coordinate } from "@pixelaw/core";
import styles from "./PwarPage.module.css";
import { StatsDashboard } from "@/components/Pwar/Stats/StatsDashboard";
import { usePwarProvider } from "@/provider/PwarContext";
import { DefaultParameters, Position } from "@pixelaw/core-dojo";
import { AccountInterface, CairoOption, CairoOptionVariant } from "starknet";
import { GameControls } from "@/components/Pwar/GameControls/GameControls";
import { GuildPanel } from "@/components/Pwar/Guild/GuildPanel";
import { GameStatusBar } from "@/components/Pwar/GameStatus/GameStatusBar";
import { DojoWallet } from "@pixelaw/core-dojo";

// The content of the Pwar page, wrapped by PwarProvider
const PwarPageContent: React.FC = () => {
  const { pixelawCore, coreStatus, center } = usePixelawProvider();
  const { viewPort: renderer } = pixelawCore;
  const rendererContainerRef = useRef<HTMLDivElement | null>(null);
  const { provider, world, wallet, account } = usePwarProvider();

  // Game state
  const [gameStarted, setGameStarted] = useState(false);
  const [gameId, setGameId] = useState<number | null>(null);
  const [selectedGuildId, setSelectedGuildId] = useState<number | null>(null);

  // Handle cell interactions
  useEffect(() => {
    const handlePwarCellClick = async (cell: Coordinate) => {
      console.log("Pwar cell clicked:", cell);

      // Only allow interaction if game has started
      if (!gameStarted) {
        console.log("Game not started yet. Please start a game first.");
        return;
      }

      try {
        // Create DefaultParameters object
        const defaultParams = {
          player_override: new CairoOption(CairoOptionVariant.None),
          system_override: new CairoOption(CairoOptionVariant.None),
          area_hint: new CairoOption(CairoOptionVariant.None),
          position: {
            x: cell[0],
            y: cell[1],
          },
          color: 255,
        } as DefaultParameters;

        // Call the interact function with the wallet and parameters
        const tx = await world.pwar_actions.interact(account, defaultParams);
        console.log("this is the tx after interact", tx);
      } catch (error) {
        console.error("Failed to interact with cell:", error);
      }
    };

    pixelawCore.events.on("cellClicked", handlePwarCellClick);
    return () => {
      pixelawCore.events.off("cellClicked", handlePwarCellClick);
    };
  }, [pixelawCore, world, gameStarted]);

  // Set up the renderer
  useEffect(() => {
    if (coreStatus !== "ready") return;
    renderer.setContainer(rendererContainerRef.current!);
  }, [coreStatus, renderer]);

  // Game control handlers
  const handleStartGame = async () => {
    try {
      // Call your contract to start a new game
      const position = {
        x: center[0],
        y: center[1],
      } as Position;
      const newGameId = await world.pwar_actions.createGame(account, position);
      console.log(newGameId);
      // setGameId(newGameId);
      setGameId(1);
      setGameStarted(true);
    } catch (error) {
      console.error("Failed to start game:", error);
    }
  };

  const handleJoinGuild = async (guildId: number) => {
    try {
      if (!gameId) return;
      await world.guild_actions.joinGuild(account, gameId, guildId);
      setSelectedGuildId(guildId);
    } catch (error) {
      console.error("Failed to join guild:", error);
    }
  };

  const handleCreateGuild = async (guildName: string) => {
    try {
      if (!gameId) return;
      const newGuildId = await world.guild_actions.createGuild(
        account,
        gameId,
        guildName,
      );
      setSelectedGuildId(newGuildId);
    } catch (error) {
      console.error("Failed to create guild:", error);
    }
  };

  const handlePayFee = async () => {
    try {
      if (!gameId) return;
      await world.payments.pay_participation_fee(account, gameId);
    } catch (error) {
      console.error("Failed to pay fee:", error);
    }
  };

  return (
    <div className={styles.pwarContainer}>
      <GameStatusBar gameStarted={gameStarted} gameId={gameId} />

      <div className={styles.gameContent}>
        <div ref={rendererContainerRef} className={styles.rendererContainer} />

        <div className={styles.pwarInterface}>
          <GameControls
            onStartGame={handleStartGame}
            onPayFee={handlePayFee}
            gameStarted={gameStarted}
          />

          <GuildPanel
            gameId={gameId}
            selectedGuildId={selectedGuildId}
            onJoinGuild={handleJoinGuild}
            onCreateGuild={handleCreateGuild}
          />

          <StatsDashboard />
        </div>
      </div>
    </div>
  );
};

// Wrap the PwarPage content with the PwarProvider
const PwarPage: React.FC = () => {
  return <PwarPageContent />;
};

export default PwarPage;
