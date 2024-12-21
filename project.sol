// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthcareSimulationGame {

    address public owner;
    uint public totalPlayers;
    uint public totalQuizzes;
    mapping(address => bool) public enrolledPlayers;
    mapping(address => uint) public playerScores;
    mapping(uint => Quiz) public quizzes;

    struct Quiz {
        string question;
        string answer;
        uint rewardPoints;
    }

    event PlayerEnrolled(address indexed player);
    event QuizCompleted(address indexed player, uint quizId, bool passed, uint rewardPoints);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyEnrolled() {
        require(enrolledPlayers[msg.sender], "You need to enroll first");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalPlayers = 0;
        totalQuizzes = 0;
    }

    // Enroll a player into the healthcare simulation game
    function enrollPlayer() external {
        require(!enrolledPlayers[msg.sender], "You are already enrolled");
        enrolledPlayers[msg.sender] = true;
        totalPlayers++;
        emit PlayerEnrolled(msg.sender);
    }

    // Add a new quiz to the game
    function addQuiz(string memory _question, string memory _answer, uint _rewardPoints) external onlyOwner {
        quizzes[totalQuizzes] = Quiz({
            question: _question,
            answer: _answer,
            rewardPoints: _rewardPoints
        });
        totalQuizzes++;
    }

    // Player completes a quiz
    function completeQuiz(uint quizId, string memory userAnswer) external onlyEnrolled {
        require(quizId < totalQuizzes, "Invalid quiz ID");
        
        Quiz storage quiz = quizzes[quizId];
        bool passed = keccak256(abi.encodePacked(userAnswer)) == keccak256(abi.encodePacked(quiz.answer));
        
        if (passed) {
            playerScores[msg.sender] += quiz.rewardPoints;
        }
        
        emit QuizCompleted(msg.sender, quizId, passed, quiz.rewardPoints);
    }

    // Get the player's score
    function getPlayerScore() external view returns (uint) {
        return playerScores[msg.sender];
    }

    // Get quiz details
    function getQuizDetails(uint quizId) external view returns (string memory, string memory, uint) {
        require(quizId < totalQuizzes, "Invalid quiz ID");
        Quiz storage quiz = quizzes[quizId];
        return (quiz.question, quiz.answer, quiz.rewardPoints);
    }
}
    