import { useState } from "react";
import { ProposalItem } from "./ProposalItem";

// Simplified Proposal type
interface Proposal {
  id: number;
  title: string;
  author: string;
  yesVotes: number;
  noVotes: number;
  isActive: boolean;
}

// Dummy data
const initialProposals: Proposal[] = [
  {
    id: 1,
    title: "Paint pixels red",
    author: "0x123",
    yesVotes: 10,
    noVotes: 5,
    isActive: true
  },
  {
    id: 2,
    title: "Paint pixels blue",
    author: "0x456",
    yesVotes: 7,
    noVotes: 8,
    isActive: true
  }
];

export const ProposalList = () => {
  const [proposals, setProposals] = useState<Proposal[]>(initialProposals);
  const [newProposal, setNewProposal] = useState("");

  const handleAddProposal = () => {
    if (!newProposal.trim()) return;
    
    const proposal: Proposal = {
      id: proposals.length + 1,
      title: newProposal,
      author: "0x" + Math.floor(Math.random() * 1000).toString(16),
      yesVotes: 0,
      noVotes: 0,
      isActive: true
    };

    setProposals([...proposals, proposal]);
    setNewProposal("");
  };

  return (
    <div className="flex flex-col gap-4 p-4">
      <div className="flex gap-2">
        <input
          type="text"
          value={newProposal}
          onChange={(e) => setNewProposal(e.target.value)}
          placeholder="Enter proposal title"
          className="flex-1 p-2 rounded bg-gray-700 text-white"
        />
        <button
          onClick={handleAddProposal}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-500"
        >
          Add
        </button>
      </div>
      
      <div className="flex flex-col gap-4">
        {proposals.map((proposal) => (
          <ProposalItem key={proposal.id} proposal={proposal} />
        ))}
      </div>
    </div>
  );
};
