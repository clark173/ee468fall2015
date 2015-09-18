public class MicroVariableListener extends MicroBaseListener {

    @Override
    public void enterDecl(MicroParser.DeclContext ctx) {
        System.out.println(ctx.getText());
    }
}
