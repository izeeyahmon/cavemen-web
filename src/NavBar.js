import React from 'react';

const NavBar = ({accounts,setAccounts}) => {
    const isConnected = Boolean(accounts[0]);
    //const accountENS = ethers.getNetwork();
    //const mminstalled = Boolean(window.ethereum);

    async function connectAccount() {
        if (window.ethereum){
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts",
            });
            setAccounts(accounts);
        }
    
    }
    return (
        <div align="right">
            {/* Connect */}
            
            {isConnected ?( 
                <p>Connected {accounts[0]}</p>
            ) : ( 
                <button onClick={connectAccount}>Connect</button>
            )}

         


        </div>
    )
    
};  

export default NavBar;