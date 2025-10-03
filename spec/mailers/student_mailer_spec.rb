require "rails_helper"

RSpec.describe StudentMailer, type: :mailer do
  describe "welcome_email" do
    let(:mail) { StudentMailer.welcome_email }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome email")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "progress_update" do
    let(:mail) { StudentMailer.progress_update }

    it "renders the headers" do
      expect(mail.subject).to eq("Progress update")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "competition_invitation" do
    let(:mail) { StudentMailer.competition_invitation }

    it "renders the headers" do
      expect(mail.subject).to eq("Competition invitation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
