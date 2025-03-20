import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { usePixelawProvider } from '@pixelaw/react';
import { PwarContractService } from '@/Provider/PwarContractInteractions';

// Define the shape of a proposal
export interface PwarProposal {
  id: number;
  title: string;
  author: string;
  yesVotes: number;
  noVotes: number;
  isActive: boolean;
  index?: number;         // For contract integration
  gameId?: number;        // For contract integration
  proposalType?: number;  // For contract integration
  targetArgs1?: number;   // For contract integration
  targetArgs2?: number;   // For contract integration
}

// Define the context value type
interface PwarContextValue {
  // State
  proposals: PwarProposal[];
  isLoading: boolean;
  error: Error | null;
  gameId: number;
  contractService: PwarContractService | null;

  // Actions
  createProposal: (title: string, proposalType: number, targetArgs1: number, targetArgs2: number) => Promise<void>;
  voteOnProposal: (proposalId: number, voteYes: boolean) => Promise<void>;
  activateProposal: (proposalId: number) => Promise<void>;
  createGame: (x: number, y: number) => Promise<void>;
}

// Create the context
const PwarContext = createContext<PwarContextValue | undefined>(undefined);

// Provider props type
interface PwarProviderProps {
  children: ReactNode;
  defaultGameId?: number;
}

// Initial dummy proposals (for development)
const initialProposals: PwarProposal[] = [
  {
    id: 1,
    title: "Paint pixels red",
    author: "0x123",
    yesVotes: 10,
    noVotes: 5,
    isActive: true,
    index: 1,
    gameId: 1,
    proposalType: 1,
    targetArgs1: 0xFF0000, // Red color in hex
    targetArgs2: 0
  },
  {
    id: 2,
    title: "Paint pixels blue",
    author: "0x456",
    yesVotes: 7,
    noVotes: 8,
    isActive: true,
    index: 2,
    gameId: 1,
    proposalType: 1,
    targetArgs1: 0x0000FF, // Blue color in hex
    targetArgs2: 0
  }
];

// Provider component
export const PwarProvider: React.FC<PwarProviderProps> = ({ children, defaultGameId = 1 }) => {
  // Get access to Pixelaw context
  const { pixelawCore } = usePixelawProvider();

  // State
  const [proposals, setProposals] = useState<PwarProposal[]>(initialProposals);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [gameId, setGameId] = useState(defaultGameId);
  const [contractService, setContractService] = useState<PwarContractService | null>(null);

  // Initialize Pwar contract service
  useEffect(() => {
    if (!pixelawCore) return;
    
    try {
      const service = new PwarContractService(pixelawCore);
      setContractService(service);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to initialize Pwar contract service'));
    }
  }, [pixelawCore]);

  // Actions
  const createProposal = async (
    title: string, 
    proposalType: number = 1, 
    targetArgs1: number = 0, 
    targetArgs2: number = 0
  ) => {
    setIsLoading(true);
    try {
      if (contractService) {
        await contractService.createProposal(gameId, proposalType, targetArgs1, targetArgs2);
      }
      
      // For now, mock the creation locally
      const newProposal: PwarProposal = {
        id: proposals.length + 1,
        title,
        author: '0x123', // Would come from account
        yesVotes: 0,
        noVotes: 0,
        isActive: true,
        index: proposals.length + 1,
        gameId,
        proposalType,
        targetArgs1,
        targetArgs2
      };
      
      setProposals([...proposals, newProposal]);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to create proposal'));
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const voteOnProposal = async (proposalId: number, voteYes: boolean) => {
    setIsLoading(true);
    try {
      const proposal = proposals.find(p => p.id === proposalId);
      
      if (!proposal) {
        throw new Error(`Proposal with id ${proposalId} not found`);
      }
      
      if (contractService && proposal.index && proposal.gameId) {
        // Default to 1 voting power for now
        await contractService.vote(proposal.gameId, proposal.index, 1, voteYes);
      }
      
      // Update local state to reflect the vote
      setProposals(proposals.map(proposal => {
        if (proposal.id === proposalId) {
          return {
            ...proposal,
            yesVotes: voteYes ? proposal.yesVotes + 1 : proposal.yesVotes,
            noVotes: !voteYes ? proposal.noVotes + 1 : proposal.noVotes,
          };
        }
        return proposal;
      }));
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to vote on proposal'));
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const activateProposal = async (proposalId: number) => {
    setIsLoading(true);
    try {
      const proposal = proposals.find(p => p.id === proposalId);
      
      if (!proposal) {
        throw new Error(`Proposal with id ${proposalId} not found`);
      }
      
      if (contractService && proposal.index && proposal.gameId) {
        await contractService.activateProposal(proposal.gameId, proposal.index);
      }
      
      // Update local state
      setProposals(proposals.map(proposal => {
        if (proposal.id === proposalId) {
          return { ...proposal, isActive: false };
        }
        return proposal;
      }));
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to activate proposal'));
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const createGame = async (x: number, y: number) => {
    setIsLoading(true);
    try {
      if (contractService) {
        const result = await contractService.createGame(x, y);
        
        // In a real implementation, you would get the new game ID from the result
        // and update the state
        const newGameId = gameId + 1;
        setGameId(newGameId);
      }
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to create game'));
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const contextValue: PwarContextValue = {
    // State
    proposals,
    isLoading,
    error,
    gameId,
    contractService,

    // Actions
    createProposal,
    voteOnProposal,
    activateProposal,
    createGame
  };

  return (
    <PwarContext.Provider value={contextValue}>
      {children}
    </PwarContext.Provider>
  );
};

// Custom hook to use the Pwar context
export const usePwar = () => {
  const context = useContext(PwarContext);
  if (context === undefined) {
    throw new Error('usePwar must be used within a PwarProvider');
  }
  return context;
};
