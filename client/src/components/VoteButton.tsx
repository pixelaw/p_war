import { DEFAULT_GAME_ID } from "@/constants";
import { useDojo } from "@/hooks/useDojo";
import { Proposal } from "@/libs/dojo/typescript/models.gen";
import { Dialog, DialogContent, DialogTrigger, DialogTitle } from "@/components/ui/Dialog";
import { useCallback, useMemo, useState } from "react";

interface VoteButtonProps {
  proposal: Proposal;
  title: string;
}

export const VoteButton: React.FC<VoteButtonProps> = ({ proposal, title }) => {
  // Hooks
  const {
    setup: {
      systemCalls: { vote },
    },
    account: { account },
    connectedAccount,
  } = useDojo();

  // State
  const activeAccount = useMemo(() => connectedAccount || account, [connectedAccount, account]);
  const [isVoting, setIsVoting] = useState(false);
  const [voteType, setVoteType] = useState<"for" | "against">("for");
  // const [votePoints, setVotePoints] = useState<number>(1);
  const [isOpen, setIsOpen] = useState(false);

  // Handlers
  const handleVote = useCallback(async () => {
    setIsVoting(true);
    try {
      vote(activeAccount, DEFAULT_GAME_ID, proposal.index, voteType === "for");
      // Add any success handling here
    } catch (error) {
      // Handle error
      console.error(error);
    } finally {
      setIsVoting(false);
      setIsOpen(false);
    }
  }, [activeAccount, proposal.index, voteType, vote]);

  // const handleVotePointsChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
  //   setVotePoints(Number(e.target.value));
  // }, []);

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger className="absolute bottom-4 right-4 rounded-md px-4 py-2 text-sm transition duration-300 bg-blue-600 text-white hover:bg-blue-500">
        Vote
      </DialogTrigger>
      <DialogContent>
        <div className="fixed inset-0 z-30 flex items-center justify-center bg-black/50">
          <div className="w-full max-w-md rounded-lg bg-gray-800 p-6 text-white shadow-lg flex flex-col space-y-4">
            <DialogTitle className="flex items-center font-bold space-x-3">
              <p className="text-sm">{title}</p>
              {title && (
                <div
                  className="size-6 rounded-md"
                  style={{
                    backgroundColor: extractHexColor(title) || undefined,
                  }}
                />
              )}
            </DialogTitle>

            <div className="flex items-center justify-between">
              <button
                className={`w-full rounded-md p-2 ${voteType === "for" ? "bg-blue-600" : "bg-gray-600"}`}
                onClick={(e) => {
                  e.preventDefault();
                  setVoteType("for");
                }}
              >
                For
              </button>
              <button
                className={`ml-4 w-full rounded-md p-2 ${voteType === "against" ? "bg-blue-600" : "bg-gray-600"}`}
                onClick={(e) => {
                  e.preventDefault();
                  setVoteType("against");
                }}
              >
                Against
              </button>
            </div>
            <div>
              <label className="mb-2 block">Voting Power: 1</label>
            </div>
            <div className="flex justify-end">
              <button className="mr-2 rounded-md bg-gray-600 px-4 py-2 text-white" onClick={() => setIsOpen(false)}>
                Cancel
              </button>
              <button className="rounded-md bg-blue-600 px-4 py-2 text-white" onClick={handleVote} disabled={isVoting}>
                {isVoting ? "Submitting..." : "Submit"}
              </button>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

// Helper function to extract hex color from title
const extractHexColor = (text: string): string | null => {
  const hexColorRegex = /#([0-9A-F]{3}){1,2}/i;
  const match = text.match(hexColorRegex);
  return match ? match[0] : null;
};
