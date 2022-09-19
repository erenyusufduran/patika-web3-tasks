// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] private todos;
    function create(string calldata _text) external {
        todos.push(Todo(_text, false));
    }

    function updateText(uint _index, string calldata _text) external {
        todos[_index].text = _text;
    }

    function getTodo(uint _index) external view returns (string memory, bool) {
        Todo memory todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}