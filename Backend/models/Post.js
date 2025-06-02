const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  PostName: { type: String, required: true },
  UserId: { type: String, required: true },
  Posttitle: { type: String, required: true },
  Discription: { type: String, required: true },
  postphoto: { type: String, required: true }, // Will store Cloudinary URL
  createdAt: { type: Date, required: true },
  likeCount: { type: Number, default: 0 },
});

module.exports = mongoose.model('Post', postSchema);
