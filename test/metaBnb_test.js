const metaBnb = artifacts.require('metaBnb');

let instance = null;

contract('metaBnb', () => {

    const buyer = '0xC00AB10238A2C48D7E952D53Ffd7a2d41c8eEb0B'
    const amount = 1;
    const priceValue = 1000;
    const value = 1000;
    const max = 1;
    const owner = '0xbafce22c4ecddd7a9e7e0c27ddd9dc92415e399d'
    const tokenId = 1;
    const sender = '0xC00AB10238A2C48D7E952D53Ffd7a2d41c8eEb0B'
    const nullValue = 0;
    const duration = 5;
    const time = 1665783;

    before(async() => {
        instance = await metaBnb.deployed()
    })

    it('buy meta house', async() => {
        try {
            await instance.buyMetaHouse(buyer,priceValue,amount);
        } catch(error) {
            assert(priceValue == value);
            assert(amount == max);
        }
    })

    it('get balance', async() => {
        try {
            await instance.balanceOf(buyer);
        } catch(error) {
            expect(value).to.equal(1)
        }
    })

    it('sell meta house', async() => {
        try {
          await instance.sellMetaHouse(buyer, owner, tokenId, amount);
        } catch(error) {
            assert(buyer == sender);
          const value = await instance.balanceOf(buyer);   
          assert(amount != nullValue)
          const value2 = await instance.getTokenState(tokenId);
          expect(value2).to.equal(false)
        }
    })

    it('rent meta house', async() => {
        try {
            await instance.rentMetaHouse(owner, buyer, tokenId, duration, amount);
        } catch(error) {
        const value = await instance.balanceOf(owner).toString();
        assert(value >= '1')
         const value2 = await instance.getTokenState(tokenId);
         expect(value2).to.equal(false)
        }
    })

   it('set lease agreement', async() => {
    try {
        await instance.setLeaseAgreement(buyer, owner, tokenId, amount, duration);
    } catch(error) {
        const value = await instance.balanceOf(buyer).toString();
        assert(value >= '1')
        const value2 = await instance.getTokenState(tokenId);
         expect(value2).to.equal(false)
    }
   })

})