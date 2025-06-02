const mongoose = require('mongoose');

const postLikeSchema = new mongoose.Schema({
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true },
  userId: { type: String, required: true },
});

module.exports = mongoose.model('PostLike', postLikeSchema);
