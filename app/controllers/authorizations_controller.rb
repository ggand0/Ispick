class AuthorizationsController < ApplicationController
  before_action :set_authorization, only: [:destroy]

  # DELETE /target_words/1
  # DELETE /target_words/1.json
  def destroy
    return redirect_to settings_users_path if current_user.authorizations.count == 1

    @authorization.destroy
    respond_to do |format|
      format.html { redirect_to settings_users_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authorization
      @authorization = Authorization.find(params[:id])
    end
end
