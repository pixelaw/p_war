import { useState, useEffect } from "react";
import { usePixelawProvider } from "@pixelaw/react";
import { usePwarProvider } from "@/provider/PwarContext";
import styles from "./StatsDashboard.module.css";

export const StatsDashboard = () => {
  const { pixelawCore } = usePixelawProvider();
  const { wallet, world, account, provider } = usePwarProvider();
  const [clickCount, setClickCount] = useState(0);
  const [pixelsPlaced, setPixelsPlaced] = useState(0);
  const [playerCommit, setPlayerCommit] = useState<number | null>(null);
  const [playerOwns, setPlayerOwns] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Track clicks
  const handleCellClick = () => {
    setClickCount((prev) => prev + 1);
  };

  // Simulate successful pixel placement
  const incrementPixelsPlaced = () => {
    setTimeout(() => {
      if (Math.random() > 0.3) {
        setPixelsPlaced((prev) => prev + 1);
      }
    }, 500);
  };

  // Fetch player data from the contract
  const fetchPlayerData = async () => {
    if (!account || !world) return;
    console.log(wallet.address);

    setIsLoading(true);
    try {
      // Get player commit data
      const commitResponse = await world.guild_actions.getPlayerCommit(account,
        wallet.address,
      );

      // Get player owns data
      const ownsResponse = await world.guild_actions.getPlayerOwns(account,
        wallet.address,
      );

      console.log("commitResponse", commitResponse);
      console.log("ownsResponse", ownsResponse);
      // Update state with fetched data
      // setPlayerCommit(Number(commitResponse));
      // setPlayerOwns(Number(ownsResponse));
    } catch (error) {
      console.error("Failed to fetch player stats:", error);
    } finally {
      setIsLoading(false);
    }
  };

  // Set up click listener
  useEffect(() => {
    pixelawCore.events.on("cellClicked", handleCellClick);
    pixelawCore.events.on("cellClicked", incrementPixelsPlaced);

    return () => {
      pixelawCore.events.off("cellClicked", handleCellClick);
      pixelawCore.events.off("cellClicked", incrementPixelsPlaced);
    };
  }, [pixelawCore]);

  // Fetch player data on component mount and when wallet changes
  useEffect(() => {
    fetchPlayerData();

    // Set up periodic refresh (every 30 seconds)
    const intervalId = setInterval(fetchPlayerData, 30000);

    return () => clearInterval(intervalId);
  }, [wallet, world]);

  return (
    <div className={styles.statsDashboard}>
      <h3>Player Stats</h3>

      <div className={styles.statsSection}>
        <div className={styles.statRow}>
          <span className={styles.statLabel}>Address:</span>
          <span className={styles.statValue}>
            {wallet
              ? `${wallet.address.slice(0, 6)}...${wallet.address.slice(-4)}`
              : "Not connected"}
          </span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Placed:</span>
          <span className={styles.statValue}>{pixelsPlaced}</span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Committed:</span>
          <span className={`${styles.statValue} ${styles.commitValue}`}>
            {isLoading ? "..." : playerCommit !== null ? playerCommit : "N/A"}
          </span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Owned:</span>
          <span className={`${styles.statValue} ${styles.ownsValue}`}>
            {isLoading ? "..." : playerOwns !== null ? playerOwns : "N/A"}
          </span>
        </div>

        <button
          className={styles.refreshButton}
          onClick={fetchPlayerData}
          disabled={isLoading}
        >
          {isLoading ? "Loading..." : "Refresh Stats"}
        </button>
      </div>
    </div>
  );
};
