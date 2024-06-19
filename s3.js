import aws from 'aws-sdk'
import crypto from 'crypto'
import { promisify } from "util"
const randomBytes = promisify(crypto.randomBytes)

const region = "us-east-2"
const bucketName = "s3bucketfinal2023"
const accessKeyId  = "AKIAYNFV7L3DV2ZMKJ6W"
const secretAccessKey = "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"
const s3 = new aws.S3({
    region,
    accessKeyId,
    secretAccessKey,
    signatureVersion: 'v4'

})

export async function generateUploadURL() {
    const rawBytes = await randomBytes(16)
    const imageName = rawBytes.toString('hex')

    const params = ({
        Bucket: bucketName,
        Key: imageName,
        Expires: 60
    })

    const uploadURL = await s3.getSignedUrlPromise('putObject', params)
    return uploadURL
}