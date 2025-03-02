const mongoose = require('mongoose');

const bloodReportSchema = new mongoose.Schema({
  ReportId: {
    type: String,
    required: true,
    unique: true
  },
  UserId: {
    type: String,
    required: true
  },
  BloodGroup: {
    type: String,
    required: true,
    enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
  },
  Hemoglobin: {
    type: Number,
    required: true,
    min: 0
  },
  RBC_Count: {
    type: Number,
    required: true,
    min: 0
  },
  WBC_Count: {
    type: Number,
    required: true,
    min: 0
  },
  Platelet_Count: {
    type: Number,
    required: true,
    min: 0
  },
  Hematocrit: {
    type: Number,
    required: true,
    min: 0
  },
  MCV: {
    type: Number,
    required: true,
    min: 0
  },
  MCH: {
    type: Number,
    required: true,
    min: 0
  },
  MCHC: {
    type: Number,
    required: true,
    min: 0
  },
  ESR: {
    type: Number,
    required: true,
    min: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('BloodReport', bloodReportSchema);