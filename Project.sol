// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VideoSeriesRewardPlatform {
    struct Video {
        uint256 id;
        address creator;
        string metadataURI;
        uint256 rewardPool;
        uint256 viewCount;
    }

    uint256 public videoCounter;
    mapping(uint256 => Video) public videos;
    mapping(address => uint256) public creatorBalances;

    event VideoUploaded(uint256 indexed id, address indexed creator, string metadataURI);
    event VideoViewed(uint256 indexed id, address indexed viewer);
    event RewardClaimed(address indexed creator, uint256 amount);

    function uploadVideo(string memory metadataURI) external {
        videoCounter++;
        videos[videoCounter] = Video({
            id: videoCounter,
            creator: msg.sender,
            metadataURI: metadataURI,
            rewardPool: 0,
            viewCount: 0
        });

        emit VideoUploaded(videoCounter, msg.sender, metadataURI);
    }

    function viewVideo(uint256 videoId) external {
        Video storage video = videos[videoId];
        require(video.id != 0, "Video does not exist");

        video.viewCount++;
        video.rewardPool += 1 ether; // Example reward for a view

        emit VideoViewed(videoId, msg.sender);
    }

    function claimRewards() external {
        uint256 reward = creatorBalances[msg.sender];
        require(reward > 0, "No rewards to claim");

        creatorBalances[msg.sender] = 0;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function distributeRewards(uint256 videoId) external {
        Video storage video = videos[videoId];
        require(video.creator == msg.sender, "Only creator can distribute rewards");
        require(video.rewardPool > 0, "No rewards to distribute");

        creatorBalances[msg.sender] += video.rewardPool;
        video.rewardPool = 0;
    }

    receive() external payable {}
}
