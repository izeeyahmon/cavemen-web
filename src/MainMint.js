import {useState} from 'react';
import { ethers,BigNumber} from 'ethers';
import GachiGasm from './GachiGasm.json';

const GachiGasmAddress = "0xd5f82cD39a6252d66F8975Df7A4993687a5b1a87";
let siglist = require("./signatures.json");
const MainMint = ({ accounts, setAccounts}) => {
    const[mintAmount] = useState(1);
    const isConnected = Boolean(accounts[0]);


    async function handleMint(){
        if(window.ethereum){
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            //const network = await ethers.providers.getNetwork();
            const contract = new ethers.Contract(
                GachiGasmAddress,
                GachiGasm.abi,
                signer
            );
            const minter = await signer.getAddress();
            const signature = siglist[minter];
            
        try{
            const response = await contract.mint(BigNumber.from(mintAmount),signature,{
                gasLimit : 100000
                //nonce: nonce || undefinedb
            });
            console.log("response:",response);
        } catch(err){
            console.log("Encountered an error",err);
            //console.log(typeof(siglist['0x1c95551CC84773c4B4D6DCEEcfe2C369F7431542']));
        
        }
        }
        
    }

    return(
        <div>
            <h1>Cavemen</h1>
            <p>Me Swypes, Me big Belly , Me want Beer</p>
            {isConnected ? (
                <div>   
                    <button onClick={handleMint}>Mint</button>
                    
                    
                </div>
            ) :(
                <p>You must be Connected to Mint.</p>
            )}
        </div>
    );
} ;

export default MainMint;

