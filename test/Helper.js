const BN = web3.utils.BN;

module.exports.expect = require('chai')
  .use(require('bn-chai')(BN))
  .expect;

module.exports.random10bn = () => {
  return this.bn(web3.utils.randomHex(10));
};

module.exports.random32 = () => {
  return web3.utils.randomHex(32);
};

module.exports.bn = (number) => {
  return web3.utils.toBN(number);
};

module.exports.getEventFromTx = (tx, contract, eventName) => {
  const eventABI = contract._jsonInterface.find(x => x.name === eventName);
  const eventRawLog = tx.receipt.rawLogs.find(x => x.topics[0] === eventABI.signature);

  return web3.eth.abi.decodeLog(
    eventABI.inputs,
    eventRawLog.data,
    eventRawLog.topics
  );
};

// the promiseFunction should be a function
module.exports.tryCatchRevert = async (promise, message, headMsg = 'revert ') => {
  if (message === '') {
    headMsg = headMsg.slice(0, -1);
    console.log('    \u001b[93m\u001b[2m\u001b[1m⬐ Warning:\u001b[0m\u001b[30m\u001b[1m There is an empty revert/require message');
  }
  try {
    if (promise instanceof Function)
      await promise();
    else
      await promise;
  } catch (error) {
    assert(
      error.message.search(headMsg + message) >= 0 || process.env.SOLIDITY_COVERAGE,
      'Expected a revert \'' + headMsg + message + '\', got \'' + error.message + '\' instead'
    );
    return;
  }
  throw new Error('Expected throw not received');
};

module.exports.toEvents = async (tx, ...events) => {
  if (tx instanceof Promise)
    tx = await tx;

  const logs = tx.logs;

  let eventObjs = [].concat.apply(
    [],
    events.map(
      event => logs.filter(
        log => log.event === event
      )
    )
  );

  if (eventObjs.length === 0 || eventObjs.some(x => x === undefined)) {
    console.log('\t\u001b[91m\u001b[2m\u001b[1mError: The event dont find');
    assert.fail();
  }
  eventObjs = eventObjs.map(x => x.args);
  return (eventObjs.length === 1) ? eventObjs[0] : eventObjs;
};
