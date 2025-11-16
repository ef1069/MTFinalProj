const mongoose = require('mongoose');

const MeetingSchema = new mongoose.Schema({
  date: Date,
  notes: String
}, { _id: false });

const BookSchema = new mongoose.Schema({
  title: String,
  author: String,
  isbn: String
}, { _id: false });

const ClubSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  books: [BookSchema],
  meetings: [MeetingSchema]
}, { timestamps: true });

module.exports = mongoose.model('Club', ClubSchema);
