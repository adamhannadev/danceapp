require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "booking_confirmation" do
    let(:mail) { BookingMailer.booking_confirmation }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "booking_reminder" do
    let(:mail) { BookingMailer.booking_reminder }

    it "renders the headers" do
      expect(mail.subject).to eq("Booking reminder")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "class_cancelled" do
    let(:mail) { BookingMailer.class_cancelled }

    it "renders the headers" do
      expect(mail.subject).to eq("Class cancelled")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "instructor_assigned" do
    let(:mail) { BookingMailer.instructor_assigned }

    it "renders the headers" do
      expect(mail.subject).to eq("Instructor assigned")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
