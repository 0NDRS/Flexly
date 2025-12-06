import { v2 as cloudinary } from 'cloudinary'

const configureCloudinary = () => {
  if (process.env.CLOUDINARY_URL) {
    return
  }

  if (
    !process.env.CLOUDINARY_CLOUD_NAME ||
    !process.env.CLOUDINARY_API_KEY ||
    !process.env.CLOUDINARY_API_SECRET
  ) {
    console.warn(
      'Cloudinary environment variables are missing. Image uploads will fail.'
    )
  }

  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  })
}

export default configureCloudinary
