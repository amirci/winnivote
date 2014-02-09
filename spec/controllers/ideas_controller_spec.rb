require 'spec_helper'

describe IdeasController do
  
  let(:user) { FactoryGirl.create :user }
  
  before :each do
    sign_in user
  end
  
  describe '#index' do
    let!(:ideas) { FactoryGirl.create_list :idea, 10 }
    before do
      controller.stub(:authenticate_user!)
      get :index
    end
    it { should respond_with :success }
    it { should render_template(:index) }
    it { assigns(:ideas).should == ideas }
  end

  describe '#new' do
    before {get :new}
    it { should respond_with :success }
    it { should render_template(:new) }
    it { assert assigns(:idea).new_record? }
  end

  describe '#create' do
    describe 'with valid params' do
      let(:idea_params) {{title: "Some title", description: "desc"}}
      before do
        @idea_count = Idea.count
        post :create, {idea: idea_params}
      end
      it { should redirect_to :root }
      it { Idea.last.title.should == idea_params[:title] }
      it { Idea.last.description.should == idea_params[:description] }
      it { Idea.count.should == @idea_count + 1 }
    end

    describe 'without valid params' do
      let(:invalid_idea_params) {{title: "", description: ""}}
      before do
        @idea_count = Idea.count
        post :create, {idea: invalid_idea_params}
      end
      it { should render_template(:new) }
      it { Idea.count.should == @idea_count }
    end
  end

  describe 'PUT #upvote' do
    let(:idea) { FactoryGirl.create(:idea) }

    before do
      Idea.stub(find: idea)
      put :upvote, id: idea.to_param, format: :json
    end

    it "increases the votes of the idea by one" do
      expect(idea.votes).to eq 1
    end
    
    it "stores the increased votes value" do
      expect(Idea.find(idea.id).votes).to eq 1
    end

    it "returns json containing the number of votes" do
      expect(response.body).to eq({votes: 1}.to_json)
    end
  end

  describe '#update' do
    let!(:ideas) { FactoryGirl.create_list :idea, 10 }
    let(:idea)   { ideas.first }
    let(:attr)   { { title:'Updated title', description:'Updated description' } }

    context "when the request is html" do
      before {put :update, id: idea.id, idea: attr}
      it { should respond_with :not_acceptable   }
    end
    
    context "when the request is JSON" do
      before {put :update, :format => :json, id: idea.id, idea: attr}

      it { should respond_with :no_content }

      it "updates the idea on the database" do
        idea.reload
        expect(idea.title).to eq attr[:title]
        expect(idea.description).to eq attr[:description]
      end
    end
  end
end
