import { DojoWallet } from "@pixelaw/core-dojo";
import { PixelawCore } from "@pixelaw/core";
import { Coordinate } from "@pixelaw/core";
import { setupWorld } from '@/config/contracts.gen';
import { DefaultParameters} from '@/config/models.gen';
import { Position } from "@pixelaw/core";
import { CairoCustomEnum, CairoOption, CairoOptionVariant, BigNumberish } from 'starknet';

export class PwarContractService {
  private pixelawCore: PixelawCore;
  private provider: any;
  private account: any;
  private world: any;
  
  constructor(pixelawCore: PixelawCore) {
    this.pixelawCore = pixelawCore;
    this.initialize();
  }
  
  private initialize() {
    try {
      const wallet = this.pixelawCore.getWallet() as DojoWallet;
      this.account = wallet.getAccount();
      this.provider = this.pixelawCore.engine["dojoSetup"].provider;
      this.world = setupWorld(this.provider);
      console.log("PwarContractService initialized");
    } catch (error) {
      console.error("Failed to initialize PwarContractService:", error);
    }
  }
  
  /**
   * Interacts with a pixel at given coordinates
   */
  // Coordinate (For rendering), Pixel(color, app -> more extensive object), Position (Object that has x and y)
  async interact(cell: Position) {
    try {
      console.log("Interacting with pixel at:", cell);
      const input: DefaultParameters = {
        player_override: 0,
        system_override: 0,
        area_hint: 0,
        position: cell,
        color: 255,
      }
      this.world.interact(this.account, input)

      return await this.provider.execute(
        this.account,
        {
          contractName: "p_war_actions",
          entrypoint: "interact",
          calldata: [
            "0x1",  // player_override
            "0x1",  // system_override
            "0x1",  // area_hint
            cell.x, cell.y, // position
            255     // color
          ]
        },
        "pixelaw"
      );
    } catch (error) {
      console.error("Failed to interact with pixel:", error);
      throw error;
    }
  }
  
  /**
   * Creates a new proposal
   */
  async createProposal(gameId: number, proposalType: number, targetArgs1: number, targetArgs2: number) {
    try {
      console.log("Creating proposal:", { gameId, proposalType, targetArgs1, targetArgs2 });
      return await this.world.propose_actions.createProposal(
        this.account,
        gameId,
        proposalType,
        targetArgs1,
        targetArgs2
      );
    } catch (error) {
      console.error("Failed to create proposal:", error);
      throw error;
    }
  }
  
  /**
   * Votes on a proposal
   */
  async vote(gameId: number, proposalIndex: number, usePx: number, isInFavor: boolean) {
    try {
      console.log("Voting on proposal:", { gameId, proposalIndex, usePx, isInFavor });
      return await this.world.voting_actions.vote(
        this.account,
        gameId,
        proposalIndex,
        usePx,
        isInFavor
      );
    } catch (error) {
      console.error("Failed to vote on proposal:", error);
      throw error;
    }
  }
  
  /**
   * Activates a proposal
   */
  async activateProposal(gameId: number, proposalIndex: number, clearData: any[] = []) {
    try {
      console.log("Activating proposal:", { gameId, proposalIndex });
      return await this.world.propose_actions.activateProposal(
        this.account,
        gameId,
        proposalIndex,
        clearData
      );
    } catch (error) {
      console.error("Failed to activate proposal:", error);
      throw error;
    }
  }
  
  /**
   * Creates a new game
   */
  async createGame(x: number, y: number) {
    try {
      console.log("Creating game at:", { x, y });
      return await this.world.p_war_actions.createGame(
        this.account,
        { x, y }
      );
    } catch (error) {
      console.error("Failed to create game:", error);
      throw error;
    }
  }
} 