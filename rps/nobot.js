#!/usr/bin/env node

var readline = require('readline');

var inited = false;
var plays = new Object();
var counters = { 'rock':'paper', 'paper':'scissors', 'scissors':'rock' };

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.on('line', function (cmd) {
  if(cmd === 'init' && !inited) {
    console.log(move(null));
    inited = true;
  }
  else if(inited) {
    var results = cmd.split(' ');
    if(plays[results[1]]) {
      plays[results[1]] = plays[results[1]] + 1;
    }
    else {
      plays[results[1]] = 1;
    }
    console.log(move(results[1]));
  }
});

var move = function(played) {
  if(!inited) {
    return 'scissors';
  }
  var mostPlayed = Object.keys(plays).sort(function(a, b) { return (plays[b] - plays[a])});
  return counters[mostPlayed[0]];
};
