import { useNavigate } from "react-router-dom";
import styles from "./WorldSelectorPage.module.css";
import { usePixelawProvider } from "@pixelaw/react";

const WorldSelectorPage = () => {
  const { pixelawCore, world, setWorld } = usePixelawProvider();

  const navigate = useNavigate();

  const handleWorldChange = (newWorld: string) => {
    setWorld(newWorld);
    navigate("/");
  };

  return (
    <div className={styles.inner}>
      <h1>World Selector: {world}</h1>
      <ul className={styles.list}>
        {Object.entries(pixelawCore.getWorldsRegistry()).map(
          ([worldKey, worldConfig]) => {
            return (
              <li
                key={worldKey}
                className={`${styles.listItem} ${world === worldKey ? styles.selected : ""}`}
              >
                <button
                  type="button"
                  className={`${styles.menuButton} ${world === worldKey ? styles.selectedButton : styles.unselectedButton}`}
                  onClick={() => handleWorldChange(worldKey)}
                >
                  {worldConfig.description}
                </button>
              </li>
            );
          },
        )}
      </ul>
    </div>
  );
};

export default WorldSelectorPage;
