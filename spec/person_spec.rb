require 'spec_helper'

describe Person do
  let(:person) { build :person }

  it { should validate_presence_of :weight }
  it { should validate_presence_of :height }

  it { should validate_numericality_of :weight }
  it { should validate_numericality_of :height }
  it { should validate_numericality_of(:gender).only_integer }

  context "validating" do
    subject { person }

    context "weight" do
      before { person.weight = weight }

      context 'where weight too small' do
        let(:weight) { 49 }

        it { should_not be_valid }
        it { should have(1).error_on(:weight) }
      end

      context "where weight too large" do
        let(:weight) { 501 }

        it { should_not be_valid }
        it { should have(1).error_on(:weight) }
      end

      context "where weight is minimum weight" do
        let(:weight) { 500 }

        it { should be_valid }
      end

      context "where weight is maximum weight" do
        let(:weight) { 50 }
        it { should be_valid }
      end

      context "where weight is in between min and max" do
        let(:weight) { 250 }
        it { should be_valid }
      end

    end

    context "height" do
      before { person.height = height }

      context 'where height too small' do
        let(:height) { 47 }

        it { should_not be_valid }
        it { should have(1).error_on(:height) }
      end

      context "where height too large" do
        let(:height) { 97 }

        it { should_not be_valid }
        it { should have(1).error_on(:height) }
      end

      context "where height is minimum height" do
        let(:height) { 48 }

        it { should be_valid }
      end

      context "where height is maximum height" do
        let(:height) { 96 }
        it { should be_valid }
      end

      context "where height is in between min and max" do
        let(:height) { 72 }
        it { should be_valid }
      end
    end

    context "gender" do
      before { person.gender = gender}

      context "where gender is female" do
        let(:gender) { 0 }
        it { should be_valid }
      end

      context "where gender is male" do
        let(:gender) { 1 }
        it { should be_valid }
      end

      context "where gender is not male or female" do
        let(:gender) { 3 }
        it { should_not be_valid }
        it { should have(1).error_on(:gender) }
      end
    end
  end

  describe "#flip_gender" do
    context "when gender is male" do

      it 'changes gender to female' do
        person.flip_gender.should eq(0)
      end
    end

    context "when gender is female" do
      before { person.gender = 0 }

      it 'changes gender to male' do
        person.flip_gender.should eq(1)
      end
    end
  end
end
