import './App.css';
import axios from 'axios';
import React, { Component } from 'react';



class App extends Component {
    state = {
        selectedFile: null,
        fileUploadedSuccessfully: false
    }

    onFileChange = event => {
        this.setState({selectedFile:event.target.file[0]})
    }

    onFileUpload = () => {
        const formData = new FormData();
        formData.append(
            'dfile',
            this.state.selectedFile,
            this.state.selectedFile.name
        )

        //call api
        //call api
        axios.post("https://l1a80aiwmk.execute-api.us-east-2.amazonaws.com/prod/file-upload", formData).then(() => {
           this.setState({selectedFile:null});
            this.setState({fileUploadedSuccessfully:true}); 
        }) 
    }


    fileData = () => {
        if (this.state.selectedFile){
            return (
            <div>
                <h2>
                    file details:
                </h2>
                <p>file name: {this.state.selectedFile.name}</p>
                <p>file type: {this.state.selectedFile.type}</p>
                <p>last modified: {" "}
                {this.state.selectedFile.lastModified.toDateString()}
                </p>
            </div>
            );
        }
        else if (this.state.fileUploadedSuccessfully){
            return(
                <div>
                    <br>
                    <h4>your file has been uploaded</h4>
                    </br>
                </div>
            );
        }
        else {
            <div>
                <br />
                <h4> choose a file</h4>
            </div>
        }
    }

    render() {
        return(
            <div>
                <h2>File Upload System</h2>
                <h3>file upload</h3>
                <div>
                    <input type= "file" onChange={this.onFileChange} />
                    <button onClick={this.onFileUpload}>
                        Upload
                        </button>
                </div>
                {this.fileData()}
            </div>
        )
    }
}
