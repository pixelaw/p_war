import GamePage from "@/pages/GamePage/GamePage.tsx";
import SettingsPage from "@/pages/SettingsPage.tsx";
import { WalletSelectorPage } from "@/pages/WalletSelectorPage.tsx";
import WorldSelectorPage from "@/pages/WorldSelectorPage.tsx";
import { Route, Routes } from "react-router-dom";
import styles from "./Main.module.css";
import PwarPage from "./pages/PwarPage/PwarPage";

function Main() {
  document.title = "PixeLAW: World";

  return (
    <div className={styles.container}>
      {/*<MenuBar />*/}

      <div className={styles.main}>
        <Routes>
          <Route path="/settings" element={<SettingsPage />} />
          <Route path="/world" element={<WorldSelectorPage />} />
          <Route path="/wallet" element={<WalletSelectorPage />} />
          <Route path="/pwar" element={<PwarPage />} />
          <Route path="/" element={<GamePage />} />
        </Routes>
      </div>
    </div>
  );
}

export default Main;
