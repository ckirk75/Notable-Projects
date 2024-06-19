const AWS = required('aws-sdk');

AWS.config.update({
    accessKeyId: '',
    secretAccessKey: '',
});

const s3  = new AWS.S3({params : {Bucket: ''}})

const UploadAWS = (params) => {
    s3.putObject(params, function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else     console.log(data);           // successful response
    /*
    data = {
     ETag: "\"6805f2cfc46c0f04559748bb039d69ae\"", 
     VersionId: "tpf3zF08nBplQK1XLOefGskR7mGDwcDk"
    }
    */
  });
};

