import { v2 as cloudinary } from 'cloudinary'

const configureCloudinary = () => {
  // If CLOUDINARY_URL is provided, we can explicitly set it to ensure it's picked up
  if (process.env.CLOUDINARY_URL) {
    // The SDK usually picks this up automatically, but setting it explicitly can help
    // if there are timing issues. However, config() doesn't take a URL string directly.
    // We can just let it be, or parse it if needed.
    // But usually, just having it in process.env before import is enough.
    // Let's log to be sure.
    console.log('Cloudinary configured via CLOUDINARY_URL')
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
